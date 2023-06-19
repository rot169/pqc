# A simple Zeek script to identify the traditional vs. quantum-resistant algorithms observed in TLS communications.
# NOTE: this is a proof-of-concept, you probably don;t want to rely on it.
# NOTE2: the TLS identifiers for algorithms are subject to change as part of the standardisation process.

module AndyPQC;
@load protocols/ssl/ssl-log-ext

export {
    redef enum Log::ID += { LOG };
    type ConnInfo: record {
        client_ip: addr;
        client_port: port;
        server_ip: addr;
        server_port: port;
        tls_version: string;
        chosen_curve: string;
        client_curves: string;
    } &log;
}

event zeek_init()
{
    # initialise logging
    Log::create_stream(LOG, [$columns=AndyPQC::ConnInfo]);
    # add post-quantum algos to zeek's default curves lookup
    # n.b. values per openquantumsafe; the 'official' values may be different when standardised
    SSL::ec_curves[512] = "frodo640aes";
    SSL::ec_curves[12032] = "p256_frodo640aes";
    SSL::ec_curves[513] = "frodo640shake";
    SSL::ec_curves[12033] = "p256_frodo640shake";
    SSL::ec_curves[514] = "frodo976aes";
    SSL::ec_curves[12034] = "p384_frodo976aes";
    SSL::ec_curves[515] = "frodo976shake";
    SSL::ec_curves[12035] = "p384_frodo976shake";
    SSL::ec_curves[516] = "frodo1344aes";
    SSL::ec_curves[12036] = "p521_frodo1344aes";
    SSL::ec_curves[517] = "frodo1344shake";
    SSL::ec_curves[12037] = "p521_frodo1344shake";
    SSL::ec_curves[922] = "kyber512";
    SSL::ec_curves[12186] = "p256_kyber512";
    SSL::ec_curves[924] = "kyber768";
    SSL::ec_curves[12188] = "p384_kyber768";
    SSL::ec_curves[925] = "kyber1024";
    SSL::ec_curves[12189] = "p521_kyber1024";
    SSL::ec_curves[577] = "bikel1";
    SSL::ec_curves[12321] = "p256_bikel1";
    SSL::ec_curves[578] = "bikel3";
    SSL::ec_curves[12322] = "p384_bikel3";
    SSL::ec_curves[579] = "bikel5";
    SSL::ec_curves[12323] = "p521_bikel5";
    SSL::ec_curves[556] = "hqc128";
    SSL::ec_curves[12268] = "p256_hqc128";
    SSL::ec_curves[557] = "hqc192";
    SSL::ec_curves[12269] = "p384_hqc192";
    SSL::ec_curves[558] = "hqc256";
    SSL::ec_curves[12270] = "p521_hqc256";
}

event ssl_established(c: connection)
{
    # lookup human-readable names of client-supported curves 
    local cc: vector of string = vector();
    for (i, curve in c$ssl$client_curves) {
        cc += {SSL::ec_curves[curve]};
    }

    # construct event
    local info: AndyPQC::ConnInfo = [$client_ip=c$id$orig_h, $client_port=c$id$orig_p,
                                     $server_ip=c$id$resp_h, $server_port=c$id$resp_p,
                                     $tls_version=c$ssl$version,
                                     $chosen_curve=c$ssl$curve,
                                     $client_curves=join_string_vec(cc, ",")];
    # push event to log
    Log::write(LOG, info);
}
