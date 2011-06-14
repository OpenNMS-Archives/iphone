package org.opennms.mobile.client.dao;

import java.util.LinkedHashSet;
import java.util.Set;

import org.opennms.mobile.client.model.Alarm;
import org.opennms.mobile.client.model.Server;

public class MockAlarmDao extends AbstractDao<Alarm> implements AlarmDao {
	private Set<Alarm> m_alarms = new LinkedHashSet<Alarm>();

	public Class<Alarm> getClassType() {
		return Alarm.class;
	}
	
	public MockAlarmDao() {
		int alarmId = 1;

		final Alarm a = new Alarm();
		a.setId(alarmId);
		a.setUei("uei for alarm #" + alarmId++);
		m_alarms.add(a);
	}

	@Override
	protected Set<Alarm> getObjects(final Server server) {
		return m_alarms;
	}

}
