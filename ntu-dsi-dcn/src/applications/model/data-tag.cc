#include "data-tag.h"
#include "ns3/tag.h"
#include "ns3/uinteger.h"

namespace ns3 {

NS_OBJECT_ENSURE_REGISTERED (DataTag);

TypeId
DataTag::GetTypeId(void)
{
	static TypeId tid = TypeId ("ns3::DataTag")
	 	.SetParent<Tag> ()
		.AddConstructor<DataTag> ()
		.AddAttribute ("pid", "Random tag to indicate parity packet",
			UintegerValue (0),
			MakeUintegerAccessor (&DataTag::GetPid),
			MakeUintegerChecker<uint64_t> ())
	;
	return tid;
}

TypeId
DataTag::GetInstanceTypeId (void) const
{
	return GetTypeId();
}

DataTag::DataTag()
	: m_pid (0)
{
}

DataTag::DataTag(uint64_t pid)
	: m_pid (pid)
{
}

void
DataTag::SetPid(uint64_t pid)
{
	m_pid = pid;
}

uint32_t
DataTag::GetSerializedSize (void) const
{
	return 8;
}

void
DataTag::Serialize (TagBuffer i) const
{
	i.WriteU64(m_pid);
}

void
DataTag::Deserialize (TagBuffer i)
{
	m_pid = i.ReadU64 ();
}

uint64_t
DataTag::GetPid () const
{
	return m_pid;
}

void DataTag::Print (std::ostream &os) const
{
	os << "Pid=" << m_pid;
}

} // namespace ns3
