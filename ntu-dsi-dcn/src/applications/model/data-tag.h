#ifndef DATA_TAG_H
#define DATA_TAG_H

#include "ns3/packet.h"

namespace ns3 {

class Tag;

class DataTag : public Tag
{
public:
	static TypeId GetTypeId (void);
	virtual TypeId GetInstanceTypeId (void) const;

	DataTag();

	DataTag(uint64_t pid);

	void SetPid (uint64_t pid);

	virtual void Serialize (TagBuffer i) const;
	virtual void Deserialize (TagBuffer i);
	virtual uint32_t GetSerializedSize () const;
	virtual void Print (std::ostream &os) const;

	uint64_t GetPid (void) const;

private:

	uint64_t m_pid;
};

} // namespace ns3

#endif /* DATA_TAG_H */
