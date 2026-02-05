package main

import (
	"github.com/usernameisnull/dataset/internal/cmd/dataloader"
	"github.com/usernameisnull/dataset/pkg/log"
)

func main() {
	log.SetDebug()

	cmd := dataloader.NewCommand()
	err := cmd.Execute()
	if err != nil {
		panic(err)
	}
}
