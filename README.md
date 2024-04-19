# 5min-idp - Quick Humanitec Demo

Your Humanitec Demo Environment in less than 3 minutes.

Required:

* [humctl](https://developer.humanitec.com/platform-orchestrator/cli/)
* docker

## Usage

### Configure

```bash
humctl login
export HUMANITEC_ORG=MY_ORG
```

### Run

* Start the toolbox

  ```bash
  docker run --rm -it -h 5min-idp --name 5min-idp --pull always \
    -e HUMANITEC_ORG \
    -v hum-5min-idp:/state \
    -v $HOME/.humctl:/root/.humctl \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --network bridge \
    ghcr.io/humanitec-tutorials/5min-idp
  ```

* Use it!

  ```bash
  ./0_install.sh # install & connect a local cluster powered by kind
  ./1_demo.sh # deploy your 1st score workload
  ./2_cleanup.sh # cleanup everything
  ```
