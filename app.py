from flask import Flask, jsonify, request
import random
import os
import logging

app = Flask(__name__)

# Basic structured logging (enterprise standard)
logging.basicConfig(
    level=logging.INFO)

# Environment configuration (Dev / Test / Prod)
APP_ENV = os.getenv("APP_ENV", "development")

# Feature flag (safe deployment concept)
FEATURE_EXTENDED_QUOTES = os.getenv("FEATURE_EXTENDED_QUOTES", "false") == "true"

quotes = [
    "DevOps is a culture, not a role.",
    "Shift left, sleep better.",
    "Automation reduces human error.",
    "It works on my machine."
]

if FEATURE_EXTENDED_QUOTES:
    quotes.append("Continuous delivery enables faster business value.")

@app.route("/")


def home():
    logging.info("Root endpoint accessed")
    return jsonify({
        "service": "Daily Wisdom Service",
        "environment": APP_ENV,
        "quote": random.choice(quotes)
    })

@app.route("/health")


def health():
    return jsonify({"status": "OK"}), 200

@app.route("/whoami")


def whoami():
    return jsonify({
        "ip_address": request.remote_addr
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

