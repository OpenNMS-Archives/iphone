package org.opennms.mobile.client.model;

import java.io.Serializable;

import org.opennms.mobile.client.dao.BeanWithId;

public class Server implements Serializable, BeanWithId {
	private static final long serialVersionUID = 5333406282742973199L;

	private String m_name;
	private String m_url;
	private String m_username;
	private String m_password;

	public Server() {
	}

	public Server(final String name, final String url, final String username, final String password) {
		m_name = name;
		m_url = url;
		m_username = username;
		m_password = password;
	}
	
	public int getId() {
		return m_name.hashCode();
	}

	public void setName(final String name) {
		m_name = name;
	}
	
	public String getName() {
		return m_name;
	}
	
	public void setUrl(final String url) {
		m_url = url;
	}
	
	public String getUrl() {
		return m_url;
	}
	
	public void setUsername(final String username) {
		m_username = username;
	}
	
	public String getUsername() {
		return m_username;
	}
	
	public void setPassword(final String password) {
		m_password = password;
	}
	
	public String getPassword() {
		return m_password;
	}
	
	@Override
	public String toString() {
		return m_url + " (" + m_name + ")";
	}
	
	/* The name must be unique, so it is the only thing we use in comparisions and hashcode. */
	@Override
	public boolean equals(final Object that) {
		if (this == that) return true;
		if (!(that instanceof Server)) return false;
		final Server thatServer = (Server)that;
		if (!this.getName().equals(thatServer.getName())) return false;
		return true;
	}
	
	@Override
	public int hashCode() {
		return 13 ^ m_name.hashCode();
	}
}
