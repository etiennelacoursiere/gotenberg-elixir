boot-gotenberg:
ifeq ($(shell docker ps -a -q -f name=gotenberg),)
	@docker run -d --rm -p 3092:3000 --name gotenberg gotenberg/gotenberg:8
	@echo -e "$(GREEN)Gotenberg service started successfully!$(NO_COLOR)"
else
	@echo -e "Gotenberg container already running"
endif

start:
	iex -S mix
