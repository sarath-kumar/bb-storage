package circular

import (
	"github.com/prometheus/client_golang/prometheus"
)

var (
	debugCounters = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: "buildbarn",
			Subsystem: "blobstore",
			Name:      "circular_debug_counters",
			Help:      "Debug counters for action and results in blobstore circular package",
		},
		[]string{"storage_type", "action", "result"})
)

const (
	debugCounterActionGet = "Get"
	debugCounterActionPut = "Put"

	debugCounterResultBlobNotFound      = "BlobNotFound"
	debugCounterResultTooManyIterations = "TooManyIterations"
	debugCounterResultError             = "Error"
	debugCounterResultNotFound          = "NotFound"
	debugCounterResultSuccess           = "Success"
)

func init() {
	prometheus.MustRegister(debugCounters)
}
