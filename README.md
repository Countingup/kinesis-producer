# Amazon kinesis producer [![Build status][semaphore-image]][semaphore-url] [![License][license-image]][license-url] [![GoDoc][godoc-img]][godoc-url]
> A KPL-like batch producer for Amazon Kinesis built on top of the official Go AWS SDK  
and using the same aggregation format that [KPL][kpl-url] use.  

### Useful links
- [Documentation][godoc-url]
- [Aggregation format][aggregation-format-url]
- [Considerations When Using KPL Aggregation][kpl-aggregation]
- [Consumer De-aggregation][de-aggregation]

### Example

```go
package main

import (
	"context"
	"log"
	"time"

	"github.com/sirupsen/logrus"
	"github.com/Countingup/kinesis-producer"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	client := kinesis.NewFromConfig(cfg)
	pr := producer.New(&producer.Config{
		StreamName:   "test",
		BacklogCount: 2000,
		Client:       client,
	})

	pr.Start()

	// Handle failures
	go func() {
		for r := range pr.NotifyFailures() {
			// r contains `Data`, `PartitionKey` and `Error()`
			log.Error(r)
		}
	}()

	go func() {
		for i := 0; i < 5000; i++ {
			err := pr.Put([]byte("foo"), "bar")
			if err != nil {
				log.WithError(err).Fatal("error producing")
			}
		}
	}()

	time.Sleep(3 * time.Second)
	pr.Stop()
}
```

#### Specifying logger implementation
`producer.Config` takes an optional `logging.Logger` implementation.

##### Using a custom logger
```go
customLogger := &CustomLogger{}

&producer.Config{
  StreamName:   "test",
  BacklogCount: 2000,
  Client:       client,
  Logger:       customLogger,
}
```

#### Using logrus

```go
import (
	"github.com/sirupsen/logrus"
	producer "github.com/Countingup/kinesis-producer"
	"github.com/Countingup/kinesis-producer/loggers"
)

log := logrus.New()

&producer.Config{
  StreamName:   "test",
  BacklogCount: 2000,
  Client:       client,
  Logger:       loggers.Logrus(log),
}
```

kinesis-producer ships with three logger implementations.

- `producer.Standard` used the standard library logger
- `loggers.Logrus` uses logrus logger
- `loggers.Zap` uses zap logger

### License
MIT

[godoc-url]: https://godoc.org/github.com/Countingup/kinesis-producer
[godoc-img]: https://img.shields.io/badge/godoc-reference-blue.svg
[kpl-url]: https://github.com/awslabs/amazon-kinesis-producer
[de-aggregation]: http://docs.aws.amazon.com/kinesis/latest/dev/kinesis-kpl-consumer-deaggregation.html
[kpl-aggregation]: http://docs.aws.amazon.com/kinesis/latest/dev/kinesis-producer-adv-aggregation.html
[aggregation-format-url]: https://github.com/Countingup/kinesis-producer/blob/master/aggregation-format.md
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: LICENSE
[semaphore-image]: https://countingup.semaphoreci.com/badges/kinesis-producer.svg?style=shields
[semaphore-url]: https://countingup.semaphoreci.com/projects/kinesis-producer

