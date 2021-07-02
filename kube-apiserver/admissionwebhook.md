# kube-apiserver extensibility points: admission controller

kube-apiserver request AdmissionReview, admissioncontroller response
AdmissionResponse

- validating admission control

evaluate based upon business logical, return true for acceptence,
otherwise false for rejection and reasons.

```python
import json
import os

from flask import jsonify, Flask, request

app = Flask(__name__)

@app.route('/', methods=['POST'])
def validation():
    review = request.get_json()
    app.logger.info('Validating AdmissionReview requst: %s',
                    json.dumps(review, indent=4))

    labels = review['request']['object']['metadata']['labels']
    response = {}
    msg = None

    if 'environment' not in list(labels):
        msg = "Every Pod requres an 'environment' label."
        response['allowed'] = False
    elif labels['environment'] not in ('dev', 'prod',):
        msg = "'environment' label must be one of 'dev' or 'prod'"
        response['allowed'] = False
    else:
        response['allowed'] = True

    status = {
        'metadata': {},
        'message': msg
    }

    response['status'] = status

    review['response'] = response
    return jsonify(review), 200

context = (
    os.environ.get('WEBHOOK_CERT', '/tls/webhook.crt'),
    os.environ.get('WEBHOOK_KEY', '/tls/webhook.key'),
)

app.run(host='0.0.0.0', port='443', debug=True, ssl_context=context)
```

- mutating admission controller

execute mutating logical such as injecting sidecar container
transparently.

```python
import base64
import json
import os

from flask import jsonify, Flask, request

app = Flask(__name__)

@app.route("/", method=["POST"])
def mutation():
    review = request.get_json()
    app.logger.info("Mutating AdmissionReview request: %s",
                    json.dumps(review, indent=4))

    response = {}

    patch = [{
        'op': 'add',
        'path': {
            'image': 'nginx',
            'name': 'proxy-sidecar',
        }
    }]

    response['allowed'] = True
    response['patch'] = base64.b64encode(json.dumps(patch)
    response['patchType'] = 'application/json-patch+json'

    review['response'] = response

    return jsonify(review), 200

context = (
    os.environ.get("WEBHOOK_CERT", "/tls/webhook.crt"),
    os.environ.get("WEBHOOK_KEY", "/tls/webhook.key"),
)

app.run(host='0.0.0.0', port='443', debug=True, ssl_context=context)
```
