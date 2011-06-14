package org.opennms.mobile.client.ui;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.opennms.mobile.client.dao.DaoFactory;
import org.opennms.mobile.client.dao.OutageDao;
import org.opennms.mobile.client.model.Outage;

import com.gwtmobile.ui.client.widgets.ListPanel;

public class OutageListPage extends EntityListPage {

	private OutageDao m_outageDao;

	private List<OutageListItem> m_rows = new ArrayList<OutageListItem>();

	public OutageListPage() {
		super();
		m_outageDao = DaoFactory.getInstance().getOutageDao();
	}

	@Override
	public void onLoad() {
		m_rows.clear();

		m_outageDao.findAll(Collections.singletonMap("limit", "10"), new OutageUpdateCallback(list));
	}
	
	private static final class OutageUpdateCallback implements DaoUpdateCallback<Outage> {
		private final ListPanel m_listPanel;

		public OutageUpdateCallback(final ListPanel listPanel) {
			m_listPanel = listPanel;
		}

		public void update(final Collection<Outage> items) {
			m_listPanel.clear();
			for (final Outage outage: items) {
				m_listPanel.add(new OutageListItem(outage));
			}
		}
	}
}
