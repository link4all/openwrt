all: bw_convert delete_chain_from_table print_quotas restore_quotas backup_quotas make_iptables_rules

print_quotas: print_quotas.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools -luci -liptbwctl
restore_quotas: restore_quotas.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools -luci -liptbwctl
backup_quotas: backup_quotas.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools -luci -liptbwctl
make_iptables_rules: make_iptables_rules.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools -luci -lm
bw_convert: bw_convert.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools
delete_chain_from_table: delete_chain_from_table.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools

%.o:%.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -rf *.o *~ .*sw* bw_convert delete_chain_from_table make_iptables_rules backup_quotas restore_quotas print_quotas
