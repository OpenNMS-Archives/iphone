package org.opennms.mobile.client.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import name.pehl.totoe.xml.client.Document;
import name.pehl.totoe.xml.client.XmlParser;

import org.junit.Before;
import org.junit.Test;

import com.google.gwt.junit.client.GWTTestCase;

public class OutageTest extends GWTTestCase {

	@Override
	public String getModuleName() {
		return "org.opennms.mobile.OpenNMS";
	}

	@Before
	@Override
	public void gwtSetUp() {
		m_outages.clear();
		Outage o = new Outage();
		o.setId(3527);
		o.setDescription("Exploding Monkeys!");
		o.setHost("mephesto.internal.opennms.com");
		o.setIpAddress("17.148.17.61");
		o.setLogMessage("Blah!");
		o.setNodeId(49);
		o.setServiceName("MAIL");
		o.setSeverity("MINOR");
		o.setUei("uei.opennms.org/nodes/nodeLostService");

		o.setIfLostService(new Date(1307998926000L));
		o.setIfRegainedService(new Date(1307998974000L));

		m_outages.add(o);
		
		o = new Outage();
		o.setId(3526);
		o.setDescription("Exploding Pandas!");
		o.setHost("mephesto.internal.opennms.com");
		o.setIpAddress("172.20.1.17");
		o.setLogMessage("Blah!");
		o.setNodeId(15);
		o.setServiceName("SSH");
		o.setSeverity("MINOR");
		o.setUei("uei.opennms.org/nodes/nodeLostService");

		o.setIfLostService(new Date(1307998514000L));
		o.setIfRegainedService(new Date(1307998544000L));

		m_outages.add(o);
	}
	
	@Test
	public void testXmlToObject() {
		final Document document = new XmlParser().parse(m_xml);
		List<Outage> outages = Outage.XML.readList(document, "/outages/outage");
		
		assertEquals(2, outages.size());

		for (int i = 0; i < m_outages.size(); i++) {
			System.out.println("processing outage (i=" + i + "): " + outages.get(i));

			final Outage fromXml = outages.get(i);
			assertNotNull(fromXml);
			final Outage fromObject = m_outages.get(i);
			assertNotNull(fromObject);
			
			assertEquals("ID should match", fromObject.getId(), fromXml.getId());
			assertEquals("Description should match", fromObject.getDescription(), fromXml.getDescription());
			assertEquals("Host should match", fromObject.getHost(), fromXml.getHost());
			assertEquals("IP Address should match", fromObject.getIpAddress(), fromXml.getIpAddress());
			assertEquals("Log message should match", fromObject.getLogMessage(), fromXml.getLogMessage());
			assertEquals("Node ID should match", fromObject.getNodeId(), fromXml.getNodeId());
			assertEquals("Service name should match", fromObject.getServiceName(), fromXml.getServiceName());
			assertEquals("Severities should match", fromObject.getSeverity(), fromXml.getSeverity());
			assertEquals("UEIs should match", fromObject.getUei(), fromXml.getUei());
			assertEquals("Lost Service should match", fromObject.getIfLostService(), fromXml.getIfLostService());
			assertEquals("Regained Service should match", fromObject.getIfRegainedService(), fromXml.getIfRegainedService());
		}
	}

	private List<Outage> m_outages = new ArrayList<Outage>();
	
	private String m_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" + 
			"<outages totalCount=\"2867\" count=\"2\">\n" + 
			"  <outage id=\"3527\">\n" + 
			"    <ifLostService>2011-06-13T17:02:06-04:00</ifLostService>\n" + 
			"    <ifRegainedService>2011-06-13T17:02:54-04:00</ifRegainedService>\n" + 
			"    <ipAddress>17.148.17.61</ipAddress>\n" + 
			"    <monitoredService status=\"A\" id=\"4492\">\n" + 
			"      <ipInterfaceId>3257</ipInterfaceId>\n" + 
			"      <serviceType id=\"35\">\n" + 
			"        <name>MAIL</name>\n" + 
			"      </serviceType>\n" + 
			"    </monitoredService>    <serviceLostEvent severity=\"MINOR\" id=\"126552\" log=\"Y\" display=\"Y\">\n" + 
			"      <createTime>2011-06-13T17:02:06.755-04:00</createTime>\n" + 
			"      <description>Exploding Monkeys!</description>\n" + 
			"      <host>mephesto.internal.opennms.com</host>\n" + 
			"      <logMessage>Blah!</logMessage>\n" + 
			"      <parms>eventReason=Java Mailer messaging exception: javax.mail.MessagingException: Exception reading response; nested exception is:\n" + 
			"        java.net.SocketTimeoutException: Read timed out(string,text)</parms>\n" + 
			"      <source>OpenNMS.Poller.DefaultPollContext</source>\n" + 
			"      <time>2011-06-13T17:02:06-04:00</time>\n" + 
			"      <uei>uei.opennms.org/nodes/nodeLostService</uei>\n" + 
			"      <ipAddress>17.148.17.61</ipAddress>\n" + 
			"      <nodeId>49</nodeId>\n" + 
			"    </serviceLostEvent>    <serviceRegainedEvent severity=\"NORMAL\" id=\"126558\" log=\"Y\" display=\"Y\">\n" + 
			"      <createTime>2011-06-13T17:02:54.956-04:00</createTime>\n" + 
			"      <description>Exploding Zebras!</description>\n" + 
			"      <host>mephesto.internal.opennms.com</host>\n" + 
			"      <logMessage>Blah!</logMessage>\n" + 
			"      <source>OpenNMS.Poller.DefaultPollContext</source>\n" + 
			"      <time>2011-06-13T17:02:54-04:00</time>\n" + 
			"      <uei>uei.opennms.org/nodes/nodeRegainedService</uei>\n" + 
			"      <ipAddress>17.148.17.61</ipAddress>\n" + 
			"      <nodeId>49</nodeId>\n" + 
			"    </serviceRegainedEvent>\n" + 
			"  </outage>\n" + 
			"  <outage id=\"3526\">    <ifLostService>2011-06-13T16:55:14-04:00</ifLostService>\n" + 
			"    <ifRegainedService>2011-06-13T16:55:44-04:00</ifRegainedService>\n" + 
			"    <ipAddress>172.20.1.17</ipAddress>\n" + 
			"    <monitoredService status=\"A\" id=\"220\">\n" + 
			"      <ipInterfaceId>215</ipInterfaceId>\n" + 
			"      <serviceType id=\"18\">\n" + 
			"        <name>SSH</name>\n" + 
			"      </serviceType>\n" + 
			"    </monitoredService>\n" + 
			"    <serviceLostEvent severity=\"MINOR\" id=\"126541\" log=\"Y\" display=\"Y\">\n" + 
			"      <createTime>2011-06-13T16:55:14.330-04:00</createTime>\n" + 
			"      <description>Exploding Pandas!</description>\n" + 
			"      <host>mephesto.internal.opennms.com</host>\n" + 
			"      <logMessage>Blah!</logMessage>\n" + 
			"      <parms>eventReason=Read timed out(string,text)</parms>\n" + 
			"      <source>OpenNMS.Poller.DefaultPollContext</source>\n" + 
			"      <time>2011-06-13T16:55:14-04:00</time>\n" + 
			"      <uei>uei.opennms.org/nodes/nodeLostService</uei>\n" + 
			"      <ipAddress>172.20.1.17</ipAddress>\n" + 
			"      <nodeId>15</nodeId>\n" + 
			"    </serviceLostEvent>\n" + 
			"    <serviceRegainedEvent severity=\"NORMAL\" id=\"126542\" log=\"Y\" display=\"Y\">\n" + 
			"      <createTime>2011-06-13T16:55:44.492-04:00</createTime>\n" + 
			"      <description>Exploding Porcupines!</description>\n" + 
			"      <host>mephesto.internal.opennms.com</host>\n" + 
			"      <logMessage>Blah!</logMessage>\n" + 
			"      <source>OpenNMS.Poller.DefaultPollContext</source>\n" + 
			"      <time>2011-06-13T16:55:44-04:00</time>\n" + 
			"      <uei>uei.opennms.org/nodes/nodeRegainedService</uei>\n" + 
			"      <ipAddress>172.20.1.17</ipAddress>\n" + 
			"      <nodeId>15</nodeId>\n" + 
			"    </serviceRegainedEvent>\n" + 
			"  </outage>\n" + 
			"</outages>";

}
