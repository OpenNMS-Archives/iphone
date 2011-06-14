package org.opennms.mobile.client.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.opennms.mobile.client.dao.AlarmDao;
import org.opennms.mobile.client.dao.DaoFactory;
import org.opennms.mobile.client.model.Alarm;

import com.google.gwt.user.client.Window;

public class AlarmListPage extends EntityListPage {

	private DaoFactory m_daoFactory;
	private AlarmDao m_alarmDao;

	private List<AlarmListItem> m_rows = new ArrayList<AlarmListItem>();

	public AlarmListPage() {
		super();
		m_daoFactory = DaoFactory.getInstance();
		m_alarmDao = m_daoFactory.getAlarmDao();
	}

	@SuppressWarnings("unused")
	private void displayError(final Throwable t, final String error) {
		if (t == null) {
			Window.alert(error);
		} else {
			Window.alert(error + "(thrown: " + t.getLocalizedMessage() + ")");
		}
	}

	@Override
	public void onLoad() {

		/*

		final Server server = m_daoFactory.getCurrentServer();
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, server.getUrl() + "/alarms?limit=100");
		builder.setHeader("Accept", "application/xml");
		builder.setHeader("Origin", server.getUrl());
		builder.setUser(server.getUsername());
		builder.setPassword(server.getPassword());

		Window.alert("builder = " + builder.getUrl());
		try {
			Request request = builder.sendRequest(null, new RequestCallback() {
				public void onError(final Request request, final Throwable exception) {
					displayError(exception, "Couldn't retrieve JSON");
				}

				public void onResponseReceived(final Request request, final Response response) {
					if (200 == response.getStatusCode()) {
						final JSONValue jsonResponse = JSONParser.parseStrict(response.getText());
						final JSONArray array = jsonResponse.isArray();
						if (array == null) {
							displayError(null, "did not get an array of objects back! " + jsonResponse.toString());
							return;
						}

						for (int i = 0; i < array.size(); i++) {
							final JSONValue value = array.get(i);
							AutoBean<? extends Alarm> bean = AutoBeanCodex
									.decode(m_alarmDao.getBeanFactory(), m_alarmDao.getClassType(), value.toString());
							final Alarm a = bean.as();
							Window.alert("found alarm: " + a);
						}
					} else {
						displayError(null, "Couldn't retrieve JSON (" + response.getStatusText() + ")");
					}
				}
			});

		} catch (final RequestException e) {
			displayError(e, "Unable to request alarm list.");
		}
		*/

		/*
		m_rows.clear();

		for (final Alarm alarm : m_alarmDao.findAll(Collections.singletonMap("limit", "10"))) {
			m_rows.add(new AlarmListItem(alarm));
		}

		list.clear();
		for (final AlarmListItem item : m_rows) {
			list.add(item);
		}
		*/
		// FIXME: implement the callback structure
	}
}
