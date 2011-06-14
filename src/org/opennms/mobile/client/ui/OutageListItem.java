package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.model.Outage;

import com.google.gwt.user.client.ui.Label;

public class OutageListItem extends EntityListItem<Outage> {
	public OutageListItem(final Outage outage) {
		super(outage);
		final Label label = new Label(outage.getId() + "");
		add(label);
	}
}
