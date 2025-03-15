#!/bin/sh

# Script to initialize Ollama with the required model for Frigate
echo "Initializing Ollama with Llava model for Frigate..."

# Wait for Ollama service to be ready
echo "Waiting for Ollama service to be ready..."
until curl -s http://192.168.3.228:11434/api/version > /dev/null; do
  echo "Ollama service not ready yet, waiting..."
  sleep 5
done

echo "Ollama service is ready. Pulling gemma3:4b model..."
# Pull the llava model for vision capabilities
curl -X POST http://192.168.3.228:11434/api/pull -d '{"name": "gemma3:4b"}'

# Wait for model to be fully pulled and ready
echo "Waiting for model to be fully loaded..."
sleep 10

# Verify model is available
MODEL_CHECK=$(curl -s http://192.168.3.228:11434/api/tags | grep -c "gemma3:4b")
if [ "$MODEL_CHECK" -gt 0 ]; then
  echo "Model gemma3:4b is available. Ollama is ready for use with Frigate."
else
  echo "Warning: Model gemma3:4b may not be fully loaded. Please check Ollama logs if Frigate has issues."
fi
