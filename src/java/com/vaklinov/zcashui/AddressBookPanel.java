package com.vaklinov.zcashui;

import java.awt.BorderLayout;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.event.TableModelListener;
import javax.swing.table.DefaultTableColumnModel;
import javax.swing.table.TableColumn;
import javax.swing.table.TableColumnModel;
import javax.swing.table.TableModel;

public class AddressBookPanel extends JPanel {


    private JPanel buildButtonsPanel() {
        JPanel panel = new JPanel();
        panel.setBorder(BorderFactory.createEtchedBorder());
        return panel;
    }

    private JScrollPane buildTablePanel() {
//        JTable table = new AddressBookTable();
        JTable table = new JTable(new AddressBookTableModel(),new DefaultTableColumnModel());
        TableColumn nameColumn = new TableColumn(0);
        TableColumn addressColumn = new TableColumn(1);
        table.addColumn(nameColumn);
        table.addColumn(addressColumn);
        JScrollPane scrollPane = new JScrollPane(table);
        return scrollPane;
    }

    public AddressBookPanel() {
        BoxLayout boxLayout = new BoxLayout(this,BoxLayout.Y_AXIS);
        setLayout(boxLayout);
        add(buildTablePanel());
        add(buildButtonsPanel());
    }
}

class AddressBookTable extends DataTable {
    AddressBookTable () {
        super(new String[0][0],new String[]{"Name","Address"});
        setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
    }
}

class AddressBookEntry {
    String name,address;
}

class AddressBookTableModel implements TableModel {

    private final List<AddressBookEntry> entries =
            new ArrayList<>();
    
    AddressBookTableModel() {
        AddressBookEntry entry = new AddressBookEntry();
        entry.name = "pesho";
        entry.address = "asdf";
        entries.add(entry);
    }
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

    @Override
    public void setValueAt(Object aValue, int rowIndex, int columnIndex) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void addTableModelListener(TableModelListener l) {
    }

    @Override
    public void removeTableModelListener(TableModelListener l) {
    }
}
