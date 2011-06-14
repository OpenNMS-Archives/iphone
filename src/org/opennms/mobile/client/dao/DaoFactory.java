package org.opennms.mobile.client.dao;

import org.opennms.mobile.client.model.Server;

public class DaoFactory {
	private static DaoFactory m_daoFactory;
	
	private Server m_currentServer = null;
	
	private ServerDao m_serverDao;
	private AlarmDao m_alarmDao;
	private OutageDao m_outageDao;
	
	
	private DaoFactory() {
	}

	public void afterPropertiesSet() {
		m_serverDao = new MockServerDao();
		m_alarmDao = new MockAlarmDao();
//		m_outageDao = new MockOutageDao();
		m_outageDao = new XmlOutageDao();
	}

	public synchronized static DaoFactory getInstance() {
		if (m_daoFactory == null) {
			m_daoFactory = new DaoFactory();
			m_daoFactory.afterPropertiesSet();
		}
		return m_daoFactory;
	}

	public ServerDao getServerDao() {
		return m_serverDao;
	}

	public AlarmDao getAlarmDao() {
		return m_alarmDao;
	}

	public OutageDao getOutageDao() {
		return m_outageDao;
	}

	public Server getCurrentServer() {
		return m_currentServer;
	}

	public void setCurrentServer(final Server server) {
		m_currentServer = server;
	}
}