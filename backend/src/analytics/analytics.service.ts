import { getFirestore } from '../shared/firestore';
import { RiskLevel, Severity } from '../shared/types';

export async function getCampusAnalytics() {
  const db = getFirestore();

  // Get all assessments
  const allAssessmentsSnap = await db.collection('assessments').get();
  const assessments = allAssessmentsSnap.docs.map((doc) => doc.data());

  if (assessments.length === 0) {
    return {
      totalAssessed: 0,
      averageScores: { dep: 0, anx: 0, str: 0 },
      weeklyTrend: [],
      riskLevelCounts: {
        NORMAL: 0,
        LOW: 0,
        MODERATE: 0,
        HIGH: 0,
        CRITICAL: 0,
      },
      severityDistribution: {
        dep: {},
        anx: {},
        str: {},
      },
    };
  }

  // Count total assessed (unique students)
  const uniqueStudents = new Set(assessments.map((a) => a.userId));
  const totalAssessed = uniqueStudents.size;

  // Calculate average scores
  let sumDep = 0,
    sumAnx = 0,
    sumStr = 0;
  assessments.forEach((a) => {
    sumDep += a.normalisedScores.dep || 0;
    sumAnx += a.normalisedScores.anx || 0;
    sumStr += a.normalisedScores.str || 0;
  });

  const averageScores = {
    dep: assessments.length > 0 ? sumDep / assessments.length : 0,
    anx: assessments.length > 0 ? sumAnx / assessments.length : 0,
    str: assessments.length > 0 ? sumStr / assessments.length : 0,
  };

  // Count risk levels
  const riskLevelCounts: Record<RiskLevel, number> = {
    NORMAL: 0,
    LOW: 0,
    MODERATE: 0,
    HIGH: 0,
    CRITICAL: 0,
  };

  assessments.forEach((a) => {
    const risk = a.riskLevel as RiskLevel;
    if (riskLevelCounts[risk] !== undefined) {
      riskLevelCounts[risk]++;
    }
  });

 // Severity distribution based on overall risk levels
const riskToSeverity: Record<RiskLevel, Severity> = {
  'CRITICAL': 'Extremely Severe',
  'HIGH': 'Severe',
  'MODERATE': 'Moderate',
  'LOW': 'Mild',
  'NORMAL': 'Normal',
};

const severityCount: Record<Severity, number> = {
  'Normal': 0,
  'Mild': 0,
  'Moderate': 0,
  'Severe': 0,
  'Extremely Severe': 0,
};

assessments.forEach((a) => {
  const severity = riskToSeverity[a.riskLevel as RiskLevel] || 'Normal';
  severityCount[severity]++;
});

const total = assessments.length;
const severityDist: Record<Severity, number> = {
  'Normal': total > 0 ? (severityCount['Normal'] / total) * 100 : 0,
  'Mild': total > 0 ? (severityCount['Mild'] / total) * 100 : 0,
  'Moderate': total > 0 ? (severityCount['Moderate'] / total) * 100 : 0,
  'Severe': total > 0 ? (severityCount['Severe'] / total) * 100 : 0,
  'Extremely Severe': total > 0 ? (severityCount['Extremely Severe'] / total) * 100 : 0,
};

  // Weekly trend (last 14 weeks)
  const weeklyTrend = generateWeeklyTrend(assessments);

  return {
    totalAssessed,
    averageScores,
    riskLevelCounts,
    severityDistribution: severityDist,
    weeklyTrend,
  };
}

/**
 * Count severity distribution for a list of severity strings.
 * Returns percentages.
 */
function countSeverities(severities: Severity[]) {
  const counts: Record<Severity, number> = {
    Normal: 0,
    Mild: 0,
    Moderate: 0,
    Severe: 0,
    'Extremely Severe': 0,
  };

  severities.forEach((sev) => {
    if (counts[sev] !== undefined) {
      counts[sev]++;
    }
  });

  const total = severities.length;
  const percentages: Record<Severity, number> = {
    Normal: total > 0 ? (counts.Normal / total) * 100 : 0,
    Mild: total > 0 ? (counts.Mild / total) * 100 : 0,
    Moderate: total > 0 ? (counts.Moderate / total) * 100 : 0,
    Severe: total > 0 ? (counts.Severe / total) * 100 : 0,
    'Extremely Severe': total > 0 ? (counts['Extremely Severe'] / total) * 100 : 0,
  };

  return percentages;
}

/**
 * Generate weekly trend data for the last 14 weeks.
 */
function generateWeeklyTrend(
  assessments: any[],
): Array<{ week: number; depression: number; anxiety: number; stress: number }> {
  const now = new Date();
  const weeks: Array<{
    week: number;
    startDate: Date;
    endDate: Date;
    assessments: any[];
  }> = [];

  // Generate 14 weeks of data, going backwards from today
  for (let i = 0; i < 14; i++) {
    const endDate = new Date(now);
    endDate.setDate(endDate.getDate() - i * 7);

    const startDate = new Date(endDate);
    startDate.setDate(startDate.getDate() - 7);

    weeks.unshift({
      week: 14 - i,
      startDate,
      endDate,
      assessments: [],
    });
  }

  // Distribute assessments into weeks
  assessments.forEach((a) => {
    const assessDate = a.takenAt?.toDate?.() || new Date(a.takenAt);
    for (const week of weeks) {
      if (assessDate >= week.startDate && assessDate <= week.endDate) {
        week.assessments.push(a);
        break;
      }
    }
  });

  // Calculate averages per week
  return weeks.map((week) => {
    if (week.assessments.length === 0) {
      return { week: week.week, depression: 0, anxiety: 0, stress: 0 };
    }

    const sumDep = week.assessments.reduce((s, a) => s + (a.normalisedScores.dep || 0), 0);
    const sumAnx = week.assessments.reduce((s, a) => s + (a.normalisedScores.anx || 0), 0);
    const sumStr = week.assessments.reduce((s, a) => s + (a.normalisedScores.str || 0), 0);

    return {
      week: week.week,
      depression: Math.round((sumDep / week.assessments.length) * 100) / 100,
      anxiety: Math.round((sumAnx / week.assessments.length) * 100) / 100,
      stress: Math.round((sumStr / week.assessments.length) * 100) / 100,
    };
  });
}
