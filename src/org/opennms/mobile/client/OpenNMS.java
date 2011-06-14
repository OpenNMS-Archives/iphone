package org.opennms.mobile.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.Scheduler;
import com.google.gwt.core.client.Scheduler.ScheduledCommand;
import com.gwtmobile.ui.client.page.Page;

public class OpenNMS implements EntryPoint {
	public void onModuleLoad() {
		Scheduler.get().scheduleDeferred(new ScheduledCommand() {			
			public void execute() {
				Page.load(new MainPage());
			}
		});
	}
}
