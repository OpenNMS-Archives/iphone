package org.opennms.mobile.client.model;

import java.util.Date;

import name.pehl.piriti.commons.client.Path;
import name.pehl.piriti.converter.client.Convert;
import name.pehl.piriti.xml.client.XmlReader;

import org.opennms.mobile.client.dao.BeanWithId;
import org.opennms.mobile.client.util.LaxDateConverter;

import com.google.gwt.core.client.GWT;

public class Outage implements BeanWithId {
	public interface OutageReader extends XmlReader<Outage> {}
	public static final OutageReader XML = GWT.create(OutageReader.class);

	@Path("@id")
	int m_id;
	
	@Path("serviceLostEvent/nodeId")
	Integer m_nodeId;
	
	@Path("ifLostService")
	@Convert(LaxDateConverter.class)
	Date m_ifLostService;
	
	@Path("ifRegainedService")
	@Convert(LaxDateConverter.class)
	Date m_ifRegainedService;
	
	@Path("ipAddress")
	String m_ipAddress;
	
	@Path("serviceLostEvent/host")
	String m_host;
	
	@Path("monitoredService/serviceType/name")
	String m_serviceName;
	
	@Path("serviceLostEvent/@severity")
	String m_severity;
	
	@Path("serviceLostEvent/logMessage")
	String m_logMessage;
	
	@Path("serviceLostEvent/description")
	String m_description;
	
	@Path("serviceLostEvent/uei")
	String m_uei;

	public int getId() {
		return m_id;
	}
	public void setId(final int id) {
		m_id = id;
	}

	public Integer getNodeId() {
		return m_nodeId;
	}
	public void setNodeId(final Integer nodeId) {
		m_nodeId = nodeId;
	}

	public Date getIfLostService() {
		return m_ifLostService;
	}
	public void setIfLostService(final Date ifLostService) {
		m_ifLostService = ifLostService;
	}

	public Date getIfRegainedService() {
		return m_ifRegainedService;
	}
	public void setIfRegainedService(final Date ifRegainedService) {
		m_ifRegainedService = ifRegainedService;
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

	public String getServiceName() {
		return m_serviceName;
	}
	public void setServiceName(final String serviceName) {
		m_serviceName = serviceName;
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

	public String getDescription() {
		return m_description;
	}
	public void setDescription(final String description) {
		m_description = description;
	}

	public String getUei() {
		return m_uei;
	}
	public void setUei(final String uei) {
		m_uei = uei;
	}
	
	@Override
	public String toString() {
		return "outage #" + m_id;
	}
}
