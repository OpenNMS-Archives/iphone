package org.opennms.mobile.client.model;

import java.util.Date;

import name.pehl.piriti.commons.client.Path;
import name.pehl.piriti.xml.client.XmlReader;

import org.opennms.mobile.client.dao.BeanWithId;

import com.google.gwt.core.client.GWT;

public class Alarm implements BeanWithId {
	public interface AlarmReader extends XmlReader<Alarm> {}
	public static final AlarmReader XML = GWT.create(AlarmReader.class);
	
	@Path("@id")
	int m_id;
	
	@Path("uei")
	String m_uei;

	@Path("firstEventTime")
	Date m_firstEventTime;
	
	@Path("lastEventTime")
	Date m_lastEventTime;
	
	@Path("@count")
	int m_eventCount;
	
	@Path("ipAddress")
	String m_ipAddress;
	
	@Path("lastEvent/host")
	String m_host;
	
	// FIXME?
	String m_label;
	
	@Path("severity")
	String m_severity;
	
	@Path("logMessage")
	String m_logMessage;
	
	@Path("ackTime")
	Date m_ackTime;
	
	@Path("ackUser")
	String m_ackUser;
	
	public int getId() {
		return m_id;
	}
	public void setId(final int id) {
		m_id = id;
	}

	public String getUei() {
		return m_uei;
	}
	public void setUei(final String uei) {
		m_uei = uei;
	}

	public Date getFirstEventTime() {
		return m_firstEventTime;
	}
	public void setFirstEventTime(final Date firstEventTime) {
		m_firstEventTime = firstEventTime;
	}

	public Date getLastEventTime() {
		return m_lastEventTime;
	}
	public void setLastEventTime(final Date lastEventTime) {
		m_lastEventTime = lastEventTime;
	}

	public int getEventCount() {
		return m_eventCount;
	}
	public void setEventCount(final int eventCount) {
		m_eventCount = eventCount;
	}

	public String getIpAddress() {
		return m_ipAddress;
	}
	public void setIpAddress(final String ipAddress) {
		m_ipAddress = ipAddress;
	}

	public String getHost() {
		return m_host;
	}
	public void setHost(final String host) {
		m_host = host;
	}

	public String getLabel() {
		return m_label;
	}
	public void setLabel(final String label) {
		m_label = label;
	}

	public String getSeverity() {
		return m_severity;
	}
	public void setSeverity(final String severity) {
		m_severity = severity;
	}

	public String getLogMessage() {
		return m_logMessage;
	}
	public void setLogMessage(final String logMessage) {
		m_logMessage = logMessage;
	}

	public Date getAckTime() {
		return m_ackTime;
	}
	public void setAckTime(final Date ackTime) {
		m_ackTime = ackTime;
	}

	public String getAckUser() {
		return m_ackUser;
	}
	public void setAckUser(final String ackUser) {
		m_ackUser = ackUser;
	}
}
