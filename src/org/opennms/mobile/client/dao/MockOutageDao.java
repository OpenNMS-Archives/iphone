package org.opennms.mobile.client.dao;

import java.util.LinkedHashSet;
import java.util.Set;

import org.opennms.mobile.client.model.Outage;
import org.opennms.mobile.client.model.Server;

public class MockOutageDao extends AbstractDao<Outage> implements OutageDao {
	private Set<Outage> m_outages = new LinkedHashSet<Outage>();

	public Class<Outage> getClassType() {
		return Outage.class;
	}
	
	public MockOutageDao() {
		int outageId = 1;
		
		final Outage o = new Outage();
		o.setId(outageId++);
		m_outages.add(o);
	}

	@Override
	protected Set<Outage> getObjects(final Server server) {
		return m_outages;
	}

}
