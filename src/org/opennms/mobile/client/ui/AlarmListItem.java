package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.model.Alarm;

import com.google.gwt.user.client.ui.Label;

public class AlarmListItem extends EntityListItem<Alarm> {
	public AlarmListItem(final Alarm alarm) {
		super(alarm);
		final Label label = new Label(alarm.getId() + ": " + alarm.getUei());
		add(label);
	}
}
