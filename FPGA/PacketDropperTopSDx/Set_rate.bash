#!/bin/bash -e
if [ $# == 0 ]
then
  echo "Usage: $0 <Serial port> <Error rate>"
  exit
fi

PORT=$1
RATE=$2

if [[ $(bc -l <<< "${RATE} >= 0 && ${RATE} <= 1") -ne 1 ]]
then
  echo "The error rate must be in the interval [0, 1]." >&2
  exit 1
fi

# Cleanup handler
Cleanup()
{
  # Remove the temporary file if it exists.
  [ -n "${TEMP_DIR}" ] && rm -fr ${TEMP_DIR}
  # Remove the process storing the serial port output if it exists.
  [ -n "${PROCESS_ID}" ] && kill ${PROCESS_ID}
}

# Wait until the serial port sends a certain reply.
Wait_for_reply()
{
  # The reply that we are waiting for.
  REPLY=$1

  # Wait at most 2 seconds for a line to be output to the temporary file.
  for ITERATION in seq 20
  do
    # Check if the reply is in the temporary file.
    if grep -q "$REPLY" ${TEMP_FILE}
    then
      # We got the reply.
      FOUND=1
      break
    fi
    # Wait a moment to stop consuming CPU time needlessly.
    sleep 0.1
  done

  # Throw an error and exit if we did not get a reply.
  if [ -z "${FOUND}" ]
  then
    echo "The FPGA did not send the desired reply.  Perhaps, you supplied the wrong serial port." >&2
    cat ${TEMP_FILE}
    exit 1
  fi
}

# Set up a handler for cleaning up on exit.
trap Cleanup EXIT

# Create a file to store the serial port output in.
TEMP_FILE=$(mktemp)

# The serial port has to be open while settings are changed with stty, so we copy all output to a file in the background.
cat ${PORT} > ${TEMP_FILE} &

# Remember the ID of the background process that we just created for cleanup purposes.
PROCESS_ID=$!

# The -crtscts option of stty is not documented in the manual.  It turns hardware flow control off.
stty -F ${PORT} 115200 cs8 raw -crtscts

# Ask the packet dropper to identify itself.
echo -en 'Identify yourself!\r' > ${PORT}

# Wait for the desired reply.
Wait_for_reply 'I am the packet dropper!'

# Send the drop rate.
echo -en "${RATE}\r" > ${PORT}

# Wait for the desired reply.
Wait_for_reply 'Consider it done!!!'

# Inform the user that everything went as planned.
echo "The drop rate was updated successfully to ${RATE}."

