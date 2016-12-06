package com.vaklinov.zcashui;

import java.awt.BorderLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.DefaultTableColumnModel;
import javax.swing.table.TableColumn;

public class AddressBookPanel extends JPanel {

    private static class AddressBookEntry {
        final String name,address;
        AddressBookEntry(String name, String address) {
            this.name = name;
            this.address = address;
        }
    }
    
    private final List<AddressBookEntry> entries =
            new ArrayList<>();

    private final Set<String> names = new HashSet<>();
    
    private JTable table;
    
    private JPanel buildButtonsPanel() {
        JPanel panel = new JPanel();
        panel.setBorder(BorderFactory.createEtchedBorder());
        return panel;
    }

    private JScrollPane buildTablePanel() {
        table = new JTable(new AddressBookTableModel(),new DefaultTableColumnModel());
        TableColumn nameColumn = new TableColumn(0);
        TableColumn addressColumn = new TableColumn(1);
        table.addColumn(nameColumn);
        table.addColumn(addressColumn);
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION); // one at a time
        table.addMouseListener(new AddressMouseListener());
        JScrollPane scrollPane = new JScrollPane(table);
        return scrollPane;
    }

    public AddressBookPanel() {
        BoxLayout boxLayout = new BoxLayout(this,BoxLayout.Y_AXIS);
        setLayout(boxLayout);
        add(buildTablePanel());
        add(buildButtonsPanel());
        
        // add some entries for testing
        AddressBookEntry entry1 = new AddressBookEntry("pesho","asdf");
        AddressBookEntry entry2 = new AddressBookEntry("gosho","fdsa");
        AddressBookEntry entry3 = new AddressBookEntry("tosho","qwer");
        entries.add(entry1);entries.add(entry2);entries.add(entry3);
    }

    private class AddressMouseListener extends MouseAdapter {

        @Override
        public void mousePressed(MouseEvent e) {
            if (e.isConsumed() || (!e.isPopupTrigger()))
                return;

            int row = table.rowAtPoint(e.getPoint());
            int column = table.columnAtPoint(e.getPoint());
            table.changeSelection(row, column, false, false);
            AddressBookEntry entry = entries.get(row);
            JPopupMenu menu = new JPopupMenu();
            JMenuItem sendCash = new JMenuItem("Send ZCash to "+entry.name);
            menu.add(sendCash);
            JMenuItem copyAddress = new JMenuItem("Copy address to clipboard");
            menu.add(copyAddress);
            JMenuItem deleteEntry = new JMenuItem("Delete "+entry.name+" from contacts");
            menu.add(deleteEntry);
            menu.show(e.getComponent(), e.getPoint().x, e.getPoint().y);
            e.consume();
        }
    }

    class AddressBookTableModel extends AbstractTableModel {

        @Override
        public int getRowCount() {
            return entries.size();
        }

        @Override
        public int getColumnCount() {
            return 2;
        }

        @Override
        public String getColumnName(int columnIndex) {
            switch(columnIndex) {
            case 0 : return "name";
            case 1 : return "address";
            default:
                throw new IllegalArgumentException("invalid column "+columnIndex);
            }
        }

        @Override
        public Class<?> getColumnClass(int columnIndex) {
            return String.class;
        }

        @Override
        public boolean isCellEditable(int rowIndex, int columnIndex) {
            return false;
        }

        @Override
        public Object getValueAt(int rowIndex, int columnIndex) {
            AddressBookEntry entry = entries.get(rowIndex);
            switch(columnIndex) {
            case 0 : return entry.name;
            case 1 : return entry.address;
            default:
                throw new IllegalArgumentException("bad column "+columnIndex);
            }
        }
    }
}