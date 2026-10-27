const fs = require('fs');
const path = require('path');

/**
 * A skill that assists in humanizing artificial text.
 * 
 * Features:
 * - Tier based rewriting
 * - Avoidance of AI stereotyped language
 * - Preservation of meaning and citations
 */
function getInstructions(tier) {
  const prompt = fs.readFileSync(path.join(__dirname, 'tiers.md'), 'utf8');
  const lines = prompt.split('\n');
  let tier_prompt_start_index = -1;
  let tier_prompt_end_index = -1;

  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes(`## [Tier ${tier}]`)) {
      tier_prompt_start_index = i + 1;
      
      for (let j = i + 1; j < lines.length; j++) {
        if (lines[j].trim().startsWith('---') || (lines[j] && lines[j].startsWith('## ['))) {
          tier_prompt_end_index = j;
          break;
        }
      }
      break;
    }
  }
  
  if (tier_prompt_start_index === -1) throw new Error("Tier not found");
  if (tier_prompt_end_index === -1) tier_prompt_end_index = lines.length;

  return lines.slice(tier_prompt_start_index, tier_prompt_end_index).join('\n');
}

module.exports = {
  getInstructions
};
