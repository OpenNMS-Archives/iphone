package org.opennms.mobile.client.ui;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Widget;
import com.gwtmobile.ui.client.page.Page;
import com.gwtmobile.ui.client.widgets.ListPanel;
import com.gwtmobile.ui.client.widgets.ScrollPanel;

public class EntityListPage extends Page {

	@UiField ListPanel list;
	@UiField ScrollPanel listContainer;
	
	private static EntityListPageUiBinder uiBinder = GWT.create(EntityListPageUiBinder.class);

	interface EntityListPageUiBinder extends UiBinder<Widget, EntityListPage> {
	}
	
	EntityListPage() {
		initWidget(uiBinder.createAndBindUi(this));
	}
}
