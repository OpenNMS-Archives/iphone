package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.model.Server;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Widget;
import com.gwtmobile.ui.client.page.Page;
import com.gwtmobile.ui.client.widgets.HeaderPanel;

public class ServerPage extends Page {

	@UiField HeaderPanel header;
	@UiField OpenNMSTabPanel tab;

	private static ServerPageUiBinder uiBinder = GWT.create(ServerPageUiBinder.class);

	interface ServerPageUiBinder extends UiBinder<Widget, ServerPage> {
	}

	private Server m_server;

	public ServerPage(final Server server) {
		initWidget(uiBinder.createAndBindUi(this));				
		m_server = server;

		header.setCaption(m_server.getName());
	}

}
