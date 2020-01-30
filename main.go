package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(run)
}

func run(ctx context.Context, evt events.SQSEvent) error {
	if len(evt.Records) == 0 {
		return errors.New("invalid message")
	}
	m := evt.Records[0]
	data, _ := json.MarshalIndent(&m, "", "  ")
	fmt.Println(string(data))
	if m.Body == "pass" {
		log.Println("lambda finished successfully")
		return nil
	}

	return errors.New("lambda failed from caller")
}
