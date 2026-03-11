#!/usr/bin/env python3
"""
Generate a keystore for Android app signing using PKCS12 format.
PKCS12 is the modern format supported by Android.
"""

import os
import datetime

def generate_keystore():
    from cryptography.hazmat.primitives.asymmetric import rsa
    from cryptography.hazmat.primitives import serialization, hashes
    from cryptography.hazmat.backends import default_backend
    from cryptography.x509.oid import NameOID
    from cryptography import x509
    
    print("Generating RSA key pair...")
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    
    # Create a self-signed certificate
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "State"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, "City"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, "UnitConverter"),
        x509.NameAttribute(NameOID.COMMON_NAME, "Unit Converter"),
    ])
    
    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        private_key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.utcnow()
    ).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=10000)
    ).sign(private_key, hashes.SHA256(), default_backend())
    
    # Save as PKCS12 with password encryption
    from cryptography.hazmat.primitives.serialization import pkcs12
    
    # Use BestAvailableEncryption for proper password protection
    pkcs12_bytes = pkcs12.serialize_key_and_certificates(
        name=b"upload",
        key=private_key,
        cert=cert,
        cas=None,
        encryption_algorithm=serialization.BestAvailableEncryption(b"unitconverter2024")
    )
    
    output_path = os.path.join(os.path.dirname(__file__), "upload-keystore.p12")
    with open(output_path, "wb") as f:
        f.write(pkcs12_bytes)
    
    print(f"Keystore generated successfully!")
    print(f"Location: {output_path}")
    print(f"Store password: unitconverter2024")
    print(f"Key password: unitconverter2024")
    print(f"Alias: upload")
    print("\nIMPORTANT: Keep this keystore safe!")
    print("- It cannot be regenerated")
    print("- You'll need it for all future updates")
    print("- Don't lose it or you won't be able to update your app")
    
    # Also create the key.properties with PKCS12 settings
    print("\nNow updating build.gradle.kts to use PKCS12...")

if __name__ == "__main__":
    generate_keystore()
