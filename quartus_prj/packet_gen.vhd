ip_v: logic_v4;				--	Version
	ip_hlen:logic_v4;			--	Header length
	ip_tos:logic_v8;			-- Service Type
	ip_len:logic_v16;			-- Total Length
	ip_id: logic_v16;			-- Identifcation
	ip_flag_frag_off:logic_v16;	-- flags-- frgrament offs
	ip_ttl:logic_v8;			-- Time To Live
	ip_checksum:logic_v16;		-- Header Checksum
	ip_protocol:logic_v8;		-- Protocol
	ip_src_addr:logic_v32;		-- Source_IP_Address
	ip_dst_addr:logic_v32;		-- Dst_IP_Address
	ip_options: logic_v32;		-- IP options if any