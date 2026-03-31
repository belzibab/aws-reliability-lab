from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
import time

app = FastAPI(title="aws-reliability-lab")

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total request count",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"]
)

@app.get("/health")
def health():
    REQUEST_COUNT.labels(method="GET", endpoint="/health", status="200").inc()
    return {"status": "healthy"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/slow")
def slow():
    start = time.time()
    time.sleep(2)
    latency = time.time() - start
    REQUEST_LATENCY.labels(endpoint="/slow").observe(latency)
    REQUEST_COUNT.labels(method="GET", endpoint="/slow", status="200").inc()
    return {"message": "slow response", "latency_seconds": latency}
