/* Copyright 2012 VMware, Inc. All rights reserved. -- VMware Confidential */
package com.vmware.utils.ssl;

import java.security.cert.X509Certificate;

import javax.net.ssl.SSLException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Responsible to verify the ssl thumbprint of the certificate presented by the
 * server we are trying to connect to. The thumbprint is the SHA-1 digest of the
 * ASN.1 DER representation of the certificate, formatted as XX:XX:XX:XX:XX
 * (case-insensitive).
 */
public class SslThumbprintVerifier {
	/**
	 * Describes the result of a thumbprint verification.
	 */
	public static enum Result {
		/** Thumbprint matches expected value */
		MATCH,
		/** Thumbprint does not match expected value */
		MISMATCH,
		/** No expected value for thumbprint yet */
		UNKNOWN
	}

	private static final Log _logger = LogFactory
			.getLog(SslThumbprintVerifier.class);
	private String[] _thumbprints;

	/**
	 * Returns the thumbprint that will be used in the verification process.
	 */
	public String getThumbprint() {
		if (_thumbprints == null || _thumbprints.length != 1) {
			return null;
		}
		return _thumbprints[0];
	}

	public void setThumbprint(String thumbprint) {
		_thumbprints = new String[] { thumbprint };
	}

	/**
	 * Returns the thumbprints that will be used in the verification process.
	 * The verification succeeds if any of the these thumbprints match the
	 * server's.
	 */
	public String[] getThumbprints() {
		return _thumbprints;
	}

	public void setThumbprints(String[] thumbprint) {
		_thumbprints = thumbprint;
	}

	/**
	 * Verifies an SSL certficate thumbprint.
	 * 
	 * @param thumbprint
	 *            The thumbprint of the first certificate in the chain.
	 * @return the result of the verification. If Result.MATCH is returned then
	 *         the certificate will be accepted. Otherwise, the standard
	 *         certificate and assertion validation mechanisms will apply.
	 */
	public Result verify(String thumbprint) {
		_logger.debug("Verifying the ssl certificate: " + thumbprint);

		// Check the service if we can verify the thumbprint
		if (_thumbprints != null) {
			for (String thumbprint2 : _thumbprints) {
				if (thumbprint2 == null || thumbprint2.length() == 0) {
					continue;
				}
				if (thumbprint2.equalsIgnoreCase(thumbprint)) {
					return SslThumbprintVerifier.Result.MATCH;
				}
			}
		}

		// If we don't know about the thumbprint, then we report that
		// the verification failed.
		return Result.MISMATCH;
	}

	/**
	 * Called on completion of successful SSL validation, whether by thumbprint
	 * or through the standard mechanisms.
	 * 
	 * @param chain
	 *            The certificate chain.
	 * @param thumbprint
	 *            The thumbprint of the first certificate in the chain.
	 * @param verifyResult
	 *            The result of the {@link #verify} operation.
	 * @param trustedChain
	 *            true iff the certificate chain is trusted, i.e. the signature
	 *            has been verified against the configured trust store.
	 * @param verifiedAssertions
	 *            true iff the certificate assertions were verified.
	 * @throws SSLException
	 *             if the connection operation should be interrupted.
	 */
	public void onSuccess(X509Certificate[] chain, String thumbprint,
			SslThumbprintVerifier.Result verifyResult, boolean trustedChain,
			boolean verifiedAssertions) throws SSLException {
		if (thumbprint == null || thumbprint.length() == 0) {
			return;
		}

		_logger.debug("Ssl certificate is verified successfully: " + thumbprint);
	}
}

