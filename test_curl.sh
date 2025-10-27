#!/bin/bash
# Test if CSS is loading
curl -s http://localhost:8000/static/dist/css/adminlte.min.css | head -1
curl -s http://localhost:8000/static/bootstrap/css/bootstrap.min.css | head -1
