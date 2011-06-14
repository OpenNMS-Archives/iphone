package org.opennms.mobile.client.dao;

import org.opennms.mobile.client.model.Server;

public interface ServerDao extends Dao<Server> {

	Server getSelection(int selection);

}
