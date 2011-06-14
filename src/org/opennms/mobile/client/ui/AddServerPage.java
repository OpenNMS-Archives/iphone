package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.dao.DaoFactory;
import org.opennms.mobile.client.dao.ServerDao;
import org.opennms.mobile.client.model.Server;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Widget;
import com.gwtmobile.ui.client.page.Page;
import com.gwtmobile.ui.client.widgets.HeaderPanel;
import com.gwtmobile.ui.client.widgets.PasswordTextBox;
import com.gwtmobile.ui.client.widgets.TextBox;
import com.gwtmobile.ui.client.widgets.UrlTextBox;

public class AddServerPage extends Page {

	private static AddServerPageUiBinder uiBinder = GWT.create(AddServerPageUiBinder.class);

	interface AddServerPageUiBinder extends UiBinder<Widget, AddServerPage> {
	}

	@UiField HeaderPanel header;
	@UiField TextBox name;
	@UiField UrlTextBox url;
	@UiField TextBox username;
	@UiField PasswordTextBox password;
	
	public AddServerPage() {
		initWidget(uiBinder.createAndBindUi(this));

		final Page myPage = this;
		header.setLeftButtonClickHandler(new ClickHandler() {
			public void onClick(final ClickEvent event) {
				myPage.goBack(null);
			}
		});
		header.setRightButtonClickHandler(new ClickHandler() {
			public void onClick(final ClickEvent event) {
				final ServerDao serverDao = DaoFactory.getInstance().getServerDao();
				serverDao.save(new Server(name.getValue(), url.getValue(), username.getValue(), password.getValue()));
				myPage.goBack(null);
			}
		});

	}

}
