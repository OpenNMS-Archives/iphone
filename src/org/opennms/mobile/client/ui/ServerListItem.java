package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.model.Server;

import com.google.gwt.user.client.ui.Label;

public class ServerListItem extends EntityListItem<Server> {

	public ServerListItem(final Server server) {
		super(server);
		add(new Label(server.getName()));
	}
}
