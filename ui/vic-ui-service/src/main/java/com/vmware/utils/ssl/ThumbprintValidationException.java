package com.vmware.utils.ssl;

import java.security.cert.X509Certificate;

import javax.net.ssl.SSLException;

/**
 * ThumbprintValidationException that includes useful additional information.
 */
public class ThumbprintValidationException extends SSLException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1856596541663168795L;
	private final X509Certificate[] _certificateChain;
	private final String _thumbprint;
	private final boolean _isTrusted;

	/**
	 * Constructor.
	 * 
	 * @param message
	 *            The error message.
	 * @param certificateChain
	 *            The failed certificate chain.
	 * @param thumbprint
	 *            The thumbprint of the first certificate in the chain.
	 * @param isTrusted
	 *            True iff the chain was confirmed by the trust store.
	 * @param cause
	 *            The root validation failure exception.
	 */
	public ThumbprintValidationException(String message,
			X509Certificate[] certificateChain, String thumbprint,
			boolean isTrusted, Throwable cause) {
		super(message, cause);
		_certificateChain = certificateChain;
		_thumbprint = thumbprint;
		_isTrusted = isTrusted;
	}

	/**
	 * Obtains the failed certificate chain.
	 * 
	 * @return the certificate chain.
	 */
	public X509Certificate[] getCertificateChain() {
		return _certificateChain;
	}

	/**
	 * Obtains the thumbprint of the first certificate in the chain.
	 * 
	 * @return the thumbprint.
	 */
	public String getThumbprint() {
		return _thumbprint;
	}

	/**
	 * Obtains the certificate chain's trust status. If this value is true, then
	 * you can assume that the assertion verification failed.
	 * 
	 * @return true iff the chain was confirmed by the configured trust store.
	 */
	public boolean getIsTrusted() {
		return _isTrusted;
	}
}
