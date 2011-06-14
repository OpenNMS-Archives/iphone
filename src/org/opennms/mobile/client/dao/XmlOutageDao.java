package org.opennms.mobile.client.dao;

import java.util.List;
import java.util.Map;
import java.util.Set;

import name.pehl.totoe.xml.client.Document;
import name.pehl.totoe.xml.client.XmlParser;

import org.opennms.mobile.client.model.Outage;
import org.opennms.mobile.client.model.Server;
import org.opennms.mobile.client.ui.DaoUpdateCallback;

import com.google.gwt.http.client.Request;
import com.google.gwt.http.client.RequestBuilder;
import com.google.gwt.http.client.RequestCallback;
import com.google.gwt.http.client.RequestException;
import com.google.gwt.http.client.Response;
import com.google.gwt.user.client.Window;

public class XmlOutageDao extends AbstractDao<Outage> implements OutageDao {

	@Override
	public Class<? extends Outage> getClassType() {
		return Outage.class;
	}

	private void displayError(final Throwable t, final String message) {
		if (t == null) {
			Window.alert(message);
		} else {
			Window.alert(message + ": error was: " + t.getLocalizedMessage());
		}
	}
	
	@Override
	public void findAll(final Map<String,String> parameters, final DaoUpdateCallback<Outage> callback) {
		final Server server = DaoFactory.getInstance().getCurrentServer();

		final RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, server.getUrl() + "/outages?limit=100");
		builder.setHeader("Accept", "application/xml");
		builder.setUser(server.getUsername());
		builder.setPassword(server.getPassword());

		try {
			builder.sendRequest(null, new RequestCallback() {
				public void onError(final Request request, final Throwable exception) {
					displayError(exception, "Couldn't retrieve JSON");
				}

				public void onResponseReceived(final Request request, final Response response) {
					if (200 == response.getStatusCode()) {
						final Document document = new XmlParser().parse(response.getText());
						final List<Outage> outages = Outage.XML.readList(document, "/outages/outage");
						callback.update(outages);
					} else {
						displayError(null, "Couldn't retrieve JSON (" + response.getStatusText() + ")");
					}
				}
			});
		} catch (final RequestException e) {
			displayError(e, "Unable to request outage list.");
		}
	}
	
	@Override
	protected Set<Outage> getObjects(final Server server) {
		throw new UnsupportedOperationException("XML DAOs must be called asynchronously");
	}

}
