package main

import (
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

const secret = "galumphing"

type params struct {
	Act       string
	Nonce     string
	Signature string
	Timeout   int64
	Offset    int
}

var (
	auditLock sync.Mutex
	auditBase int
	auditLog  []string
)

var (
	seenLock sync.Mutex
	seenMap  = map[string]bool{}
)

var (
	clockAsk  = make(chan bool)
	clockTime = make(chan int64, 1)
)

func main() {
	// The following functions are actually the desired API URLs.

	http.HandleFunc("/501/access", handleAccess) // Looking at the function, there might be an access API that should be called before other API
	http.HandleFunc("/501/clock", handleClock)
	http.HandleFunc("/501/audit", handleAudit)

	err := http.ListenAndServe(os.Args[1], nil)
	if err != nil {
		log.Fatal(err)
	}
}

// the function limits the number of Audit requests to 10.
func checkCapacity(w http.ResponseWriter) (ok bool) {
	auditLock.Lock()
	defer auditLock.Unlock()

	if len(auditLog) > 10 {
		w.WriteHeader(http.StatusServiceUnavailable)
		return
	}

	ok = true
	return
}

// log the audit
func audit(r *http.Request, params params, ok bool) {
	auditLock.Lock()
	defer auditLock.Unlock()

	auditLog = append(auditLog, fmt.Sprintf("%v %q %q", ok, r.URL.Path, params.Act))
}

// parse the request headers.
func parse(w http.ResponseWriter, r *http.Request) (params params, ok bool) {
	defer func() {
		if !ok {
			audit(r, params, false)
		}
	}()

	// The headers for the response.
	w.Header().Set("Access-Control-Allow-Methods", "POST2, OPTIONS")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Max-Age", "3600")

	// the request needs to be POST, at least for the above 3 requests. Otherwise, the 'ok' parameter won't be 'true'
	if r.Method != "POST" {
		w.Header().Set("Allow", "POST, OPTIONS")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
		} else {
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
		return
	}

	// decode the params into the given structure
	// the params should be set like raw (not json/form-urlencoded)
	err := json.NewDecoder(r.Body).Decode(&params)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		log.Printf("%s: %v", r.URL.Path, err)
		return
	}

	// the request has to be validated using the SH256 comapre of path. act. nonce, and secret
	h := sha256.New()
	fmt.Fprintf(h, "%s\r\n%s\r\n%s\r\n%s", r.URL.Path, params.Act, params.Nonce, secret)
	sig := base64.StdEncoding.EncodeToString(h.Sum(nil))
	if subtle.ConstantTimeCompare([]byte(sig), []byte(params.Signature)) != 1 {
		w.WriteHeader(http.StatusForbidden)
		return
	}

	seenLock.Lock()
	seen := seenMap[params.Signature]
	if !seen {
		seenMap[params.Signature] = true
	}
	seenLock.Unlock()
	if seen {
		w.WriteHeader(http.StatusForbidden)
		return
	}

	ok = true
	return
}

func handleAccess(w http.ResponseWriter, r *http.Request) {
	if !checkCapacity(w) {
		return
	}

	// parse the request using the above function
	params, ok := parse(w, r)
	if !ok {
		return
	}

	// different values for Act request body
	switch params.Act {
	case "begin":
		if params.Timeout < 0 || params.Timeout > 250000 {
			w.WriteHeader(http.StatusBadRequest)
			audit(r, params, false)
			return
		}

		timer := time.NewTimer(time.Duration(params.Timeout) * time.Microsecond)

		select {
		case clockAsk <- true: // https://golang.org/ref/spec#Send_statements
			w.WriteHeader(http.StatusNoContent)
			audit(r, params, true)

		case <-timer.C:
			w.WriteHeader(http.StatusConflict)
			audit(r, params, false)
			return
		}

		go func() {
			<-timer.C

			select {
			case <-clockTime:
			default:
			}
		}()

	case "end":
		if params.Timeout < 0 {
			w.WriteHeader(http.StatusBadRequest)
			audit(r, params, false)
			return
		}

		timer := time.NewTimer(time.Duration(params.Timeout) * time.Microsecond)

		select {
		case value := <-clockTime: // https://golang.org/ref/spec#Receive_operator
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(http.StatusOK)
			fmt.Fprintln(w, value)
			audit(r, params, true)

		case <-timer.C:
			w.WriteHeader(http.StatusConflict)
			audit(r, params, false)
		}

	default:
		w.WriteHeader(http.StatusBadRequest)
		audit(r, params, false)
	}
}

func handleClock(w http.ResponseWriter, r *http.Request) {
	if !checkCapacity(w) {
		return
	}

	params, ok := parse(w, r)
	if !ok {
		return
	}

	switch params.Act {
	case "observe":
		if params.Timeout != 0 {
			w.WriteHeader(http.StatusBadRequest)
			audit(r, params, false)
			return
		}

		select {
		case <-clockAsk: // https://golang.org/ref/spec#Receive_operator
			select {
			case clockTime <- time.Now().Unix(): // https://golang.org/ref/spec#Send_statements
			default:
			}

		default:
		}

		w.WriteHeader(http.StatusNoContent)
		audit(r, params, true)

	default:
		w.WriteHeader(http.StatusBadRequest)
		audit(r, params, false)
	}
}

func handleAudit(w http.ResponseWriter, r *http.Request) {
	params, ok := parse(w, r)
	if !ok {
		return
	}

	ok = false

	func() {
		auditLock.Lock()
		defer auditLock.Unlock()

		switch params.Act {
		case "":
			if params.Offset != 0 {
				w.WriteHeader(http.StatusBadRequest)
				return
			}

			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(http.StatusOK)
			fmt.Fprintln(w, auditBase)

		case "burble":
			if params.Offset < auditBase || params.Offset > auditBase+len(auditLog) {
				w.WriteHeader(http.StatusBadRequest)
				return
			}

			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(http.StatusOK)

			for i := params.Offset - auditBase; i < len(auditLog); i++ {
				fmt.Fprintf(w, "%d %s\n", auditBase+i, auditLog[i])
			}

		case "chortle":
			if params.Offset > auditBase+len(auditLog) {
				w.WriteHeader(http.StatusBadRequest)
				return
			}

			if params.Offset > auditBase {
				auditLog = auditLog[params.Offset-auditBase:] // https://golang.org/ref/spec#Slice_expressions
				auditBase = params.Offset
			}

			w.WriteHeader(http.StatusNoContent)

		default:
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		ok = true
	}()

	audit(r, params, ok)
}
