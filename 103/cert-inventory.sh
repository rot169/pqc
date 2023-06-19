# A simple shell command to scan a filesystem for certificate files identift the traditional vs quantum-resistant aignature algorithm
# NOTE: Ensure this is run with the OQS-enabled version of OpenSSL installed if you want it to understand quantum-resistant algos!

find / -name "*.crt" -exec sh -c '  \
  echo -n "{}," &&  \
  openssl x509 -in "{}" -noout -text |  \
  awk -F ": " "/Public Key Algorithm/{print \$2}"'  \
  \; 2> /dev/null
