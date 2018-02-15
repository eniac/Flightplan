#include "parity-tag.h"
#include "ns3/tag.h"
#include "ns3/uinteger.h"

namespace ns3 {

NS_OBJECT_ENSURE_REGISTERED (ParityTag);

TypeId
ParityTag::GetTypeId(void)
{
	static TypeId tid = TypeId ("ns3::ParityTag")
	 	.SetParent<Tag> ()
		.AddConstructor<ParityTag> ()
		.AddAttribute ("pid", "Random tag to indicate parity packet",
			UintegerValue (0),
			MakeUintegerAccessor (&ParityTag::GetPid),
			MakeUintegerChecker<uint64_t> ())
	;
	return tid;
}

TypeId
ParityTag::GetInstanceTypeId (void) const
{
	return GetTypeId();
}

ParityTag::ParityTag()
	: m_pid (0)
{
}

ParityTag::ParityTag(uint64_t pid)
	: m_pid (pid)
{
}

void
ParityTag::SetPid(uint64_t pid)
{
	m_pid = pid;
}

uint32_t
ParityTag::GetSerializedSize (void) const
{
	return 8;
}

void
ParityTag::Serialize (TagBuffer i) const
{
	i.WriteU64(m_pid);
}

void
ParityTag::Deserialize (TagBuffer i)
{
	m_pid = i.ReadU64 ();
}

uint64_t
ParityTag::GetPid () const
{
	return m_pid;
}

void ParityTag::Print (std::ostream &os) const
{
	os << "Pid=" << m_pid;
}

} // namespace ns3
