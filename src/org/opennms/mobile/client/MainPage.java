/*
 * Copyright (c) 2010 Zhihua (Dennis) Jiang
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.opennms.mobile.client;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.opennms.mobile.client.dao.DaoFactory;
import org.opennms.mobile.client.dao.ServerDao;
import org.opennms.mobile.client.model.Server;
import org.opennms.mobile.client.ui.AddServerPage;
import org.opennms.mobile.client.ui.DaoUpdateCallback;
import org.opennms.mobile.client.ui.ServerListItem;
import org.opennms.mobile.client.ui.ServerPage;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Widget;
import com.gwtmobile.ui.client.event.SelectionChangedEvent;
import com.gwtmobile.ui.client.page.Page;
import com.gwtmobile.ui.client.page.Transition;
import com.gwtmobile.ui.client.widgets.HeaderPanel;
import com.gwtmobile.ui.client.widgets.ListPanel;
import com.gwtmobile.ui.client.widgets.ScrollPanel;

public class MainPage extends Page {
	@UiField HeaderPanel header;
	@UiField ListPanel list;
	@UiField ScrollPanel listContainer;
	
	private List<ServerListItem> m_rows = new ArrayList<ServerListItem>();

	private ServerDao m_serverDao;

	private static MainPageUiBinder uiBinder = GWT.create(MainPageUiBinder.class);

	interface MainPageUiBinder extends UiBinder<Widget, MainPage> {
	}

	public MainPage() {
		initWidget(uiBinder.createAndBindUi(this));

		m_serverDao = DaoFactory.getInstance().getServerDao();
		
		final Page myPage = this;
		header.setRightButtonClickHandler(new ClickHandler() {
			public void onClick(final ClickEvent event) {
				final AddServerPage addServerPage = new AddServerPage();
				myPage.goTo(addServerPage, Transition.SLIDEUP);
			}
		});
	}

	@Override
	public void onLoad() {
		super.onLoad();
		DaoFactory.getInstance().setCurrentServer(null);
		updateServerList();
	}

	@UiHandler("list")
	public void onListSelectionChanged(final SelectionChangedEvent e) {
		final ServerListItem item = m_rows.get(e.getSelection());
		final Server server = item.getEntity();
		DaoFactory.getInstance().setCurrentServer(server);
		this.goTo(new ServerPage(server));
	}

	protected void updateServerList() {
		final ListPanel listPanel = new ListPanel();
		listPanel.setShowArrow(true);

		m_serverDao.findAll(null, new ServerUpdateCallback(list, m_rows));
	}

	private static class ServerUpdateCallback implements DaoUpdateCallback<Server> {
		private ListPanel m_panel;
		private List<ServerListItem> m_rows;

		public ServerUpdateCallback(final ListPanel panel, final List<ServerListItem> rows) {
			m_panel = panel;
			m_rows = rows;
		}

		@Override
		public void update(final Collection<Server> items) {
			m_rows.clear();
			for (final Server item : items) {
				m_rows.add(new ServerListItem(item));
			}
			
			m_panel.clear();
			for (final ServerListItem item : m_rows) {
				m_panel.add(item);
			}
		}

	}

}
