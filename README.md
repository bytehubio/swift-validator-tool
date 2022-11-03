# validator-tool

Add to .profile path to config

```sh
export SWIFT_VALIDATOR_TOOL_CONFIG="home/user/validator-tool-config.json"
```

config example:

```json
{
  "config": {
    "url": "https://devnet.evercloud.dev/1234567890",
    "wc": 0,
    "endpoints": [
      "https://devnet.evercloud.dev/1234567890"
    ]
  },
  "endpoints_map": {
    "local": [
      "http://localhost"
    ],
    "mainnet": [
      "https://mainnet.evercloud.dev/1234567890"
    ],
    "devnet": [
      "https://devnet.evercloud.dev/221d107cd88b4da19c57c2aabf76deb9"
    ]
  }
}
```

config priority:

 - endpoints
 - url
 - endpoints_map
 
 help for use
 
 ```
 validator-tool --help
```
