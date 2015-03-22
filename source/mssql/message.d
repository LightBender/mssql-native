module mssql.message;

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
	private immutable (packet)[] _packets;

	@property immutable messageType type() { return _type; }
	@property immutable (packet)[] packets() { return _packets; }

	this(byte[] data, messageType type, ushort maxPacketLen) immutable pure
	{
		int packetDataLen = maxPacketLen - 8;

		_type = type;
	}
}

public class packet
{
	private immutable (byte)[] _data;
	private immutable messageType _type;
	private immutable packetStatus _status;
	private immutable ushort _length;
	private immutable ushort _spid;
	private immutable byte _packetId;
	private immutable byte _window;

	@property immutable (byte)[] data() { return _data; }
	@property immutable messageType type() { return _type; }
	@property immutable packetStatus status() { return _status; }
	@property immutable ushort length() { return _length; }
	@property immutable ushort spid() { return _spid; }
	@property immutable byte packetId() { return _packetId; }
	@property immutable byte window() { return _window; }

	this(byte[] data, messageType type, packetStatus status, ushort length, byte packetId, ushort spid = 0, byte window = 0x00) immutable pure
	{
		_data = data.idup;
		_type = type;
		_status = status;
		_length = length;
		_packetId = packetId;
		_spid = spid;
		_window = window;
	}
}