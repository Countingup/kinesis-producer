.PHONY: messages
messages: messages.pb.go

messages.pb.go: messages.proto
	protoc --go_out=. --go_opt=module=producer messages.proto
