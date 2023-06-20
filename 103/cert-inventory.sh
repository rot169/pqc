# A simple shell command to scan a filesystem for certificate files identift the traditional vs quantum-resistant aignature algorithm
# NOTE: Ensure this is run with the OQS-enabled version of OpenSSL installed if you want it to understand quantum-resistant algos!

# How it works:
# 1. Use find to locate all files named *.crt. For each file found, execute a series of commands:
# 2. First, print the full path and name to the matched file.
# 3. Then, run (the OQS quantum-enabled version of) openssl to parse the contents of the matched file.
# 4. Pipe the output of openssl through awk to extract only the value of the ‘Public Key Algorithm’ property, and print it.
# 5. Send any errors (e.g., if find or openssl don’t have permissions to read a file or folder) to /dev/null.

find / -name "*.crt" -exec sh -c '  \
  echo -n "{}," &&  \
  openssl x509 -in "{}" -noout -text |  \
  awk -F ": " "/Public Key Algorithm/{print \$2}"'  \
  \; 2> /dev/null

