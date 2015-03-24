module mssql.message;

import std.algorithm;
import std.bitmanip;

public enum messageType : byte 
{
	Batch = 1,
	LegacyLogin = 2,
	RPC = 3,
	TabularResult = 4,
	Attention = 6,
	BulkData = 7,
	TransactionManager = 14,
	Login = 16,
	SSPI = 17,
	PreLogin = 18
}

public enum packetStatus : byte
{
	Normal = 0x00,
	EOM = 0x01,
	Ignore = 0x02,
	Reset = 0x08,
	ResetSkipTran = 0x10
}

public class message
{
	private immutable messageType _type;
	private packet[] _packets;

	@property immutable messageType type() pure { return _type; }
	@property packet[] packets() pure { return _packets; }

	public this(ubyte[] data, messageType type, ushort maxPacketLen) pure
	{
		int packetDataLen = maxPacketLen - 8;
		_type = type;

		if((data.length+8) <= maxPacketLen)
			_packets ~= new packet(data[0..data.length], type, packetStatus.Normal, cast(ushort)data.length, cast(ubyte)0);
		else
		{
			int count = 0;
			int pos = 0;
			bool more = true;
			while(more)
			{
				_packets ~= new packet(data[pos..pos+packetDataLen], type, packetStatus.Normal, cast(ushort)packetDataLen, cast(ubyte)count++);
				pos += packetDataLen;
				if((pos+packetDataLen) >= data.length) more = false;
			}
			_packets ~= new packet(data[pos..data.length], type, packetStatus.Normal, cast(ushort)(data.length-pos), cast(ubyte)count);
		}
	}
}

public class packet
{
	private ubyte[] _data;
	private immutable messageType _type;
	private immutable packetStatus _status;
	private immutable ushort _length;
	private immutable ushort _spid;
	private immutable ubyte _packetId;
	private immutable ubyte _window;

	public @property ubyte[] data() pure { return _data; }
	public @property immutable messageType type() pure { return _type; }
	public @property immutable packetStatus status() pure { return _status; }
	public @property immutable ushort length() pure { return _length; }
	public @property immutable ushort spid() pure { return _spid; }
	public @property immutable ubyte packetId() pure { return _packetId; }
	public @property immutable ubyte window() pure { return _window; }

	public this(ubyte[] data, messageType type, packetStatus status, ushort length, ubyte packetId, ushort spid = 0, ubyte window = 0x00) pure
	{
		_data.length = length + 8;
		_data[0] = type;
		_data[1] = status;
		_data[2..3].write!ushort(length, 0);
		_data[4..5].write!ushort(spid, 0);
		_data[6] = packetId;
		_data[7] = window;
		_data[8..length+8] = data.dup[0..length];

		_type = type;
		_status = status;
		_length = length;
		_packetId = packetId;
		_spid = spid;
		_window = window;
	}
}