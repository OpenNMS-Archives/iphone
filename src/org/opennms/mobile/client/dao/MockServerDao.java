package org.opennms.mobile.client.dao;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.opennms.mobile.client.model.Server;
import org.opennms.mobile.client.ui.DaoUpdateCallback;

public class MockServerDao extends AbstractDao<Server> implements ServerDao {
	private Set<Server> m_servers = new LinkedHashSet<Server>();

	public MockServerDao() {
		m_servers.add(new Server("OpenNMS Demo", "http://demo.opennms.org/opennms/rest", "demo", "demo"));
		m_servers.add(new Server("Localhost", "http://localhost:8980/opennms/rest", "admin", "admin"));
	}

	@Override
	protected Set<Server> getObjects(Server server) {
		return m_servers;
	}

	/*
	public Server get(final int id) {
		for (final Server server : m_servers) {
			if (server.getId() == id) {
				return server;
			}
		}
		return null;
	}
	*/
	
	public Server getSelection(final int index) {
		if (index >= m_servers.size()) throw new IndexOutOfBoundsException();
		int count = 0;
		for (final Server server : m_servers) {
			if (index == count) {
				return server;
			}
			count++;
		}
		return null;
	}

	/*
	public Collection<Server> findAll(final Map<String, String> parameters) {
		final int limit = AbstractDao.getLimit(parameters);
		
		if (limit == 0) {
			return m_servers;
		}
		
		int count = 0;
		final Set<Server> retServers = new LinkedHashSet<Server>();
		for (final Server server : m_servers) {
			if (count++ == limit) {
				break;
			}
			retServers.add(server);
		}

		return retServers;
	}
	*/

	@Override
	public void findAll(final Map<String, String> parameters, final DaoUpdateCallback<Server> callback) {
		callback.update(filter(parameters, m_servers));
	}

	public Collection<Server> findAll() {
		return m_servers;
	}

	public void save(final Server server) {
		m_servers.add(server);
	}

	public Class<? extends Server> getClassType() {
		return Server.class;
	}
}
