test-install-nvim:
	docker run -it --rm \
	-v $(PWD):/scripts \
	ubuntu:22.04 /bin/bash -c "apt update -y && apt install -y wget && cd /scripts && chmod +x ./install_nvim.sh && ./install_nvim.sh && /bin/bash"
